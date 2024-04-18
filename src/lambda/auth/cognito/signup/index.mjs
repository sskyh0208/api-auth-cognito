import {
  SignUpCommand,
  CognitoIdentityProviderClient,
} from "@aws-sdk/client-cognito-identity-provider";
import crypto from 'crypto';

const COGNITO_CLIENT_ID = process.env.COGNITO_CLIENT_ID;
const COGNITO_CLIENT_SECRET = process.env.COGNITO_CLIENT_SECRET;

const HEADERS = {
  "Access-Control-Allow-Credentials": "true",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Origin": "http://localhost:3000",
  "Access-Control-Allow-Methods": "POST"
};

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
  console.log(email);
  console.log(password);

  const secretHash = getSecretHash(email);

  const command = new SignUpCommand({
    ClientId: COGNITO_CLIENT_ID,
    Username: email,
    Password: password,
    SecretHash: secretHash,
    ValidationData: [
      { Name: "username", Value: email },
      { Name: "password", Value: password },
    ],
    UserAttributes: [{ Name: "email", Value: email }],
  });

  try {
    const response = await client.send(command);
    console.log(`${email} has signed up successfully`)
    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify(response)
    }
  } catch (error) {
    console.error(error);

    if (error.name === 'UsernameExistsException'
        || error.name === 'InvalidParameterException'
        || error.name === 'InvalidPasswordException') {
      return {
        statusCode: 400,  
        headers: HEADERS,
        body: JSON.stringify({ message: error.name })
      }
    }

    return {
      statusCode: 400,
      headers: HEADERS,
      body: JSON.stringify({ message: 'UnknownError' })
    }
  }
};