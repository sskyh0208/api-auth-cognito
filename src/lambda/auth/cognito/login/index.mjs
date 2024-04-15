import {
  AuthFlowType,
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
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
  const { email, password } = JSON.parse(event.body);

  const secretHash = getSecretHash(email);

  const command = new InitiateAuthCommand({
    AuthFlow: AuthFlowType.USER_PASSWORD_AUTH,
    AuthParameters: {
      USERNAME: email,
      PASSWORD: password,
      SECRET_HASH: secretHash,
    },
    ClientId: COGNITO_CLIENT_ID,
  });

  try {
    const response = await client.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify(response)
    }
  } catch (error) {
    console.error(error);

    if (error.__type === 'NotAuthorizedException') {
      return {
        statusCode: 401,
        body: JSON.stringify({ message: 'Invalid credentials' })
      }
    }
    
    if (error.__type === 'UserNotConfirmedException') {
      return {
        statusCode: 401,
        body: JSON.stringify({ message: 'User is not confirmed' })
      }
    }

    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Something went wrong' })
    }
  }
};