#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { LambdaApiLearningStack } from '../lib/lambda-api-learning-stack';

const app = new cdk.App();

new LambdaApiLearningStack(app, 'IacLearningLambdaApiStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION || 'us-east-1',
  },
  description: 'IaC Learning - Lambda + API Gateway created with AWS CDK',
});

app.synth();
