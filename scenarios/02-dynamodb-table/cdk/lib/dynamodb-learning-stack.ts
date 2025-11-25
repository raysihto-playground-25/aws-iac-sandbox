import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';

export class DynamoDbLearningStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create DynamoDB table
    const table = new dynamodb.Table(this, 'LearningTable', {
      // Let CDK auto-generate a unique table name
      partitionKey: {
        name: 'PK',
        type: dynamodb.AttributeType.STRING,
      },
      sortKey: {
        name: 'SK',
        type: dynamodb.AttributeType.STRING,
      },
      
      // On-demand billing (free tier friendly)
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      
      // Enable point-in-time recovery
      pointInTimeRecovery: true,
      
      // Enable server-side encryption
      encryption: dynamodb.TableEncryption.AWS_MANAGED,
      
      // Enable TTL
      timeToLiveAttribute: 'ExpiresAt',
      
      // For learning purposes: allow easy cleanup
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // Add tags
    cdk.Tags.of(table).add('Name', 'IaC Learning DynamoDB Table');
    cdk.Tags.of(table).add('Environment', 'learning');
    cdk.Tags.of(table).add('ManagedBy', 'CDK');
    cdk.Tags.of(table).add('Purpose', 'Learning IaC tools comparison');

    // Outputs
    new cdk.CfnOutput(this, 'TableName', {
      value: table.tableName,
      description: 'Name of the created DynamoDB table',
      exportName: 'IacLearningDynamoDbTableName',
    });

    new cdk.CfnOutput(this, 'TableArn', {
      value: table.tableArn,
      description: 'ARN of the created DynamoDB table',
      exportName: 'IacLearningDynamoDbTableArn',
    });
  }
}
