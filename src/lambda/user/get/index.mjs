import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { 
  GetCommand,
  DynamoDBDocumentClient
} from "@aws-sdk/lib-dynamodb";

const DYNAMODB_TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;
const DYNAMODB_TABLE_PK = process.env.DYNAMODB_TABLE_PK;
const DYNAMODB_TABLE_SK = process.env.DYNAMODB_TABLE_SK;

const DYNAMODB_TABLE_SK_VALUE = "USER";
const GET_ATTRIBUTES = [
  "id", "email", "profile_image", "createdAt", "updatedAt"
]

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

const HEADERS = {
  "Access-Control-Allow-Credentials": "true",
  "Access-Control-Allow-Headers" : "Content-Type",
  "Access-Control-Allow-Origin": "http://localhost:3000",
  "Access-Control-Allow-Methods": "POST"
};

export const handler = async (event) => {
  const user_id = event.requestContext.authorizer.claims.sub;

  const command = new GetCommand({
    TableName: DYNAMODB_TABLE_NAME,
    Key: {
      [DYNAMODB_TABLE_PK]: user_id,
      [DYNAMODB_TABLE_SK]: DYNAMODB_TABLE_SK_VALUE
    },
    ProjectionExpression: GET_ATTRIBUTES.join(", ")
  });

  try {
    const { Item } = await docClient.send(command);

    console.log(`User ${user_id} has been retrieved successfully`);

    if (!Item) {
      return {
        statusCode: 404,
        headers: HEADERS,
        body: JSON.stringify({ message: 'UserNotFoundException' })
      }
    }
    return {
      statusCode: 200,
      headers: HEADERS,
      body: JSON.stringify(Item),
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: error.$metadata.httpStatusCode,
      headers: HEADERS,
      body: JSON.stringify({ message: error.name })
    }
  }
}