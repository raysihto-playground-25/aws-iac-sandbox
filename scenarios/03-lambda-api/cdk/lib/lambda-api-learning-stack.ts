import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigatewayv2 from 'aws-cdk-lib/aws-apigatewayv2';
import * as apigatewayv2_integrations from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as path from 'path';

export class LambdaApiLearningStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create Lambda function
    const apiFunction = new lambda.Function(this, 'ApiFunction', {
      runtime: lambda.Runtime.PYTHON_3_11,
      handler: 'index.lambda_handler',
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda')),
      timeout: cdk.Duration.seconds(30),
      environment: {
        ENVIRONMENT: 'learning',
      },
      logRetention: logs.RetentionDays.ONE_WEEK,
    });

    // Add tags to Lambda
    cdk.Tags.of(apiFunction).add('Name', 'IaC Learning Lambda Function');
    cdk.Tags.of(apiFunction).add('Environment', 'learning');
    cdk.Tags.of(apiFunction).add('ManagedBy', 'CDK');

    // Create HTTP API Gateway
    const httpApi = new apigatewayv2.HttpApi(this, 'HttpApi', {
      description: 'IaC Learning HTTP API',
    });

    // Add tags to API Gateway
    cdk.Tags.of(httpApi).add('Name', 'IaC Learning HTTP API');
    cdk.Tags.of(httpApi).add('Environment', 'learning');
    cdk.Tags.of(httpApi).add('ManagedBy', 'CDK');

    // Create Lambda integration
    const lambdaIntegration = new apigatewayv2_integrations.HttpLambdaIntegration(
      'LambdaIntegration',
      apiFunction
    );

    // Add route
    httpApi.addRoutes({
      path: '/',
      methods: [apigatewayv2.HttpMethod.GET],
      integration: lambdaIntegration,
    });

    // Outputs
    new cdk.CfnOutput(this, 'ApiEndpoint', {
      value: httpApi.url || '',
      description: 'HTTP API endpoint URL',
      exportName: 'IacLearningLambdaApiEndpoint',
    });

    new cdk.CfnOutput(this, 'FunctionName', {
      value: apiFunction.functionName,
      description: 'Name of the Lambda function',
      exportName: 'IacLearningLambdaFunctionName',
    });

    new cdk.CfnOutput(this, 'FunctionArn', {
      value: apiFunction.functionArn,
      description: 'ARN of the Lambda function',
      exportName: 'IacLearningLambdaFunctionArn',
    });

    new cdk.CfnOutput(this, 'ApiId', {
      value: httpApi.httpApiId,
      description: 'ID of the HTTP API',
    });
  }
}
