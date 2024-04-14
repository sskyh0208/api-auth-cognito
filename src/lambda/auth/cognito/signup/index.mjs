import {
  SignUpCommand,
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
  const { email, password } = event;
  
  const secretHash = getSecretHash(email);

  const command = new SignUpCommand({
    ClientId: COGNITO_CLIENT_ID,
    Username: email,
    Password: password,
    SecretHash: secretHash,
    UserAttributes: [{ Name: "email", Value: email }],
  });

  try {
    const response = await client.send(command);

    return {
      statusCode: 200,
      body: JSON.stringify(response)
    }
  } catch (error) {
    console.error(error);

    if (error.__type === 'UsernameExistsException') {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: 'Username already exists' })
      }
    }

    if (error.__type === 'NotAuthorizedException') {
      return {
        statusCode: 401,
        body: JSON.stringify({ message: 'Invalid credentials' })
      }
    }

    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Something went wrong' })
    }
  }
};