#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { DynamoDbLearningStack } from '../lib/dynamodb-learning-stack';

const app = new cdk.App();

new DynamoDbLearningStack(app, 'IacLearningDynamoDbStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION || 'us-east-1',
  },
  description: 'IaC Learning - DynamoDB Table created with AWS CDK',
});

app.synth();
