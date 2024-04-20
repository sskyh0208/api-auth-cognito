import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { 
  PutCommand,
  DynamoDBDocumentClient
} from "@aws-sdk/lib-dynamodb";

const DYNAMODB_TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;
const DYNAMODB_TABLE_PK = process.env.DYNAMODB_TABLE_PK;
const DYNAMODB_TABLE_SK = process.env.DYNAMODB_TABLE_SK;

const DYNAMODB_TABLE_SK_VALUE = "USER";
const DEFAULT_PROFILE_IMAGE = "/avatar0.svg";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  const userAttribures = event.request.userAttributes;
  const email = userAttribures.email;
  const username = userAttribures.sub;
  const jstNow = new Date().toLocaleString(
    "ja-JP", { timeZone: "Asia/Tokyo" }
  );
  
  const user = {
    [DYNAMODB_TABLE_PK]: username,
    [DYNAMODB_TABLE_SK]: DYNAMODB_TABLE_SK_VALUE,
    id: username,
    email: email,
    profile_image: DEFAULT_PROFILE_IMAGE,
    createdAt: jstNow,
    updatedAt: jstNow
  };
  console.log(user);
  
  const command = new PutCommand({
    TableName: DYNAMODB_TABLE_NAME,
    Item: user
  });

  try {
    await docClient.send(command);
    console.log(`User ${email} has been created successfully`);
    return event;
  } catch (error) {
    console.error(error);
    return event;
  }
}