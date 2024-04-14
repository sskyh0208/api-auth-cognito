import {
  ConfirmSignUpCommand,
  CognitoIdentityProviderClient,
} from "@aws-sdk/client-cognito-identity-provider";
import crypto from 'crypto';

const COGNITO_CLIENT_ID = process.env.COGNITO_CLIENT_ID;
const COGNITO_CLIENT_SECRET = process.env.COGNITO_CLIENT_SECRET;

const client = new CognitoIdentityProviderClient({});

const getSecretHash = (username) => {
  const bytesMessage = Buffer.from(username + COGNITO_CLIENT_ID);
  const bytesSecret = Buffer.from(COGNITO_CLIENT_SECRET);
  const hmac = crypto.createHmac('sha256', bytesSecret);
  hmac.update(bytesMessage);

  return hmac.digest('base64');
};

export const handler = async (event) => {
  const { username, confirmationCode } = event;
  
  const secretHash = getSecretHash(username);

  const command = new ConfirmSignUpCommand({
    ClientId: COGNITO_CLIENT_ID,
    Username: username,
    ConfirmationCode: confirmationCode,
    SecretHash: secretHash,
  });
  try {
    const response = await client.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify(response)
    }
  } catch (error) {
    console.error(error);

    if (error.__type === 'ExpiredCodeException') {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'Confirmation code has expired' })
      }
    }

    if (error.__type === 'CodeMismatchException') {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'Invalid confirmation code' })
      }
    }

    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Something went wrong' })
    }
  }
};