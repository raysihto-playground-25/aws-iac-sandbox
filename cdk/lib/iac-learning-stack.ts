import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class IacLearningStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create S3 bucket with versioning and encryption
    const bucket = new s3.Bucket(this, 'LearningBucket', {
      // Generate unique bucket name with random suffix
      bucketName: `iac-learning-bucket-${this.account}-${cdk.Stack.of(this).region}`.toLowerCase(),
      
      // Enable versioning
      versioned: true,
      
      // Enable server-side encryption with S3-managed keys
      encryption: s3.BucketEncryption.S3_MANAGED,
      
      // Block all public access
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      
      // Don't delete bucket when stack is destroyed (safety measure)
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      
      // Auto-delete objects when destroying stack (for learning purposes)
      // In production, you'd likely want RETAIN
      autoDeleteObjects: false,
      
      // Enforce SSL/TLS for all requests
      enforceSSL: true,
    });

    // Add tags
    cdk.Tags.of(bucket).add('Name', 'IaC Learning Bucket');
    cdk.Tags.of(bucket).add('Environment', 'learning');
    cdk.Tags.of(bucket).add('ManagedBy', 'CDK');
    cdk.Tags.of(bucket).add('Purpose', 'Learning IaC tools comparison');

    // Outputs
    new cdk.CfnOutput(this, 'BucketName', {
      value: bucket.bucketName,
      description: 'Name of the created S3 bucket',
      exportName: 'IacLearningBucketName',
    });

    new cdk.CfnOutput(this, 'BucketArn', {
      value: bucket.bucketArn,
      description: 'ARN of the created S3 bucket',
      exportName: 'IacLearningBucketArn',
    });

    new cdk.CfnOutput(this, 'BucketRegion', {
      value: this.region,
      description: 'Region where the bucket is created',
    });
  }
}
