import {
  GlobalSignOutCommand,
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

export const handler = async (event) => {
  console.log(`Event: ${JSON.stringify(event)}`);
  const accessToken = JSON.parse(event.body).accessToken;

  const command = new GlobalSignOutCommand({
    AccessToken: accessToken
  });

  try {
    const response = await client.send(command);
    console.log(`User has been signed out successfully`);
    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify(response)
    }
  } catch (error) {
    console.error(error);

    return {
      statusCode: 400,
      headers: HEADERS,
      body: JSON.stringify({ message: 'UnknownError' })
    }
  }
};