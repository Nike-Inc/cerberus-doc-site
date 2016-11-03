---
layout: documentation
title: Deleting a Cerberus Environment
---

1. Delete the contents of all the s3 buckets associated with the env.
    - CloudFormation stacks created by our CLI will begin with `${env}-${component}-${hash}`
    - The easiest way to do this with the AWS CLI
        - `aws s3 rm s3://${BUCKET NAME} --recursive`
    - a note about the the buckets with versioning (Base Config is version enabled)
        - To empty a bucket with versioning enabled, you have the following options:
            - Delete the bucket programmatically using the AWS SDK.
            - Use the bucket's lifecycle configuration to request that Amazon S3 delete the objects.
            - Use the Amazon S3 console (can only use this option if your bucket contains less than 100,000 items—including both object versions and delete markers).
2. In the AWS Console locate the following CloudFormation stacks and delete them in the CloudFormation web ui panel.
    - `${env}-gateway-${hash}`
        - This one might take a while to delete.
        - This may fail because new logs may get written into the bucket in-between the time you delete the contents and the bucket attempts to get deleted.
            - This is ok, once it fails, empty the bucket again and just re-delete the stack.
    - `${env}-cms-${hash}`
    - `${env}-vault-${hash}`
    - `${env}-consul-${hash}`
    - `${env}-lambda-${hash}`
3. Finally delete the `${env}-base-${hash}` stack
    - Please note that all instances launched in this VPC will need to be terminated prior to deleting this stack or it will fail.
    - So if you have manually added instances that are not associated with the above stacks that you deleted, you will need to manually delete them.
4. Now that the VPC and all the AWS Resources have been deleted the only thing remaining is the certs we uploaded. Unfortunately you must use the AWS CLI for this step. Run the following commands
    - `aws iam list-server-certificates | grep ${env}`
    - For each of the certs that are in the `/cerberus/${env}/` path run the following command to delete it, using the cert name which is the last section of the arn ex: `cms_7e0a04d4-77e7-4c5a-8905-9cbaffd0c291`
    - `aws iam delete-server-certificate --server-certificate-name cms_7e0a04d4-77e7-4c5a-8905-9cbaffd0c291`
