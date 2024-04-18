import {
  AuthFlowType,
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
} from "@aws-sdk/client-cognito-identity-provider";
import crypto from 'crypto';

const COGNITO_CLIENT_ID = process.env.COGNITO_CLIENT_ID;
const COGNITO_CLIENT_SECRET = process.env.COGNITO_CLIENT_SECRET;

const HEADERS = {
  "Access-Control-Allow-Credentials": "true",
  "Access-Control-Allow-Headers" : "Content-Type",
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
  console.log(event);
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
    console.log(`${email} has logged in successfully`)
    return {
      statusCode: 200,
      // TODO: ある程度開発が進んだら、CORSの設定を何か別の方法で行う
      headers: HEADERS,
      body: JSON.stringify(response)
    }
  } catch (error) {
    console.error(error);

    if (error.name === 'NotAuthorizedException') {
      return {
        statusCode: 401,
        headers: HEADERS,
        body: JSON.stringify({ message: error.name })
      }
    }
    
    if (error.name === 'UserNotConfirmedException') {
      return {
        statusCode: 401,
        headers: HEADERS,
        body: JSON.stringify({ message: error.name })
      }
    }

    if (error.name === 'UserNotFoundException') {
      return {
        statusCode: 401,
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