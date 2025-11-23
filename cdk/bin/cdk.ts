#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { IacLearningStack } from '../lib/iac-learning-stack';

const app = new cdk.App();

new IacLearningStack(app, 'IacLearningCdkStack', {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION || 'us-east-1',
  },
  description: 'IaC Learning - S3 Bucket created with AWS CDK',
});

app.synth();
