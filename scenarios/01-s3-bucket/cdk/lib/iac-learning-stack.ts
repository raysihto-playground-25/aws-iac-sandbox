import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class IacLearningStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create S3 bucket with versioning and encryption
    const bucket = new s3.Bucket(this, 'LearningBucket', {
      // Let CDK auto-generate a unique bucket name based on stack name and resource ID
      // This ensures uniqueness while being deterministic and trackable
      // Format: iaclearningcdkstack-learningbucket<unique-id>-<hash>
      
      // Enable versioning
      versioned: true,
      
      // Enable server-side encryption with S3-managed keys
      encryption: s3.BucketEncryption.S3_MANAGED,
      
      // Block all public access
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
      
      // For learning purposes: allow easy cleanup
      // ⚠️ IMPORTANT: In production, use RETAIN to prevent accidental data loss!
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      
      // Auto-delete objects when destroying stack (for learning purposes)
      // ⚠️ IMPORTANT: In production, set this to false!
      autoDeleteObjects: true,
      
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
