# ERB Documentation

## cloudformation/stack.yaml.erb

### Parameters:

- id - The logical ID of the resource.
- url - The url of the S3 bucket where the template is located.
- params - An array of key value pairs representing the input parameters for the stack. E.g.:

  ```
  {
  'key' => 'ParameterName',
  'value' => 'parameterValue'
  }
  ```

- tags - An array of key value pairs reporesenting tags for the stack. E.g.:

  ```
  {
  'key' => 'TagName',
  'value' => 'tagValue'
  }
  ```

## cloudfront/cloudfront.yaml.erb

Creates a cloudfront distribution and adds the DNS record sets to the appropriate hosted zone.

### Cloudformation Parameters

- ProjectName - The name of the project.
- RootDomain - The domain that this domain is based upon.

### Parameters

- id - The logical ID of the resource.
- webAcl - (Optional) The logical ID of the WebACL resource to associate with this cloudfront instance.

## codebuild/buildspecs/copy-s3-to-s3.yaml.erb

Using a zip file as the build source, copy the source resources to another S3 bucket.

### Parameters

- cloudfront - (Optional) If true, adds cloudfront invalidation to the buildspec.

## codebuild/buildspecs/static-website.yaml.erb

Using codepipeline as the build source, copy the resources to an S3 bucket and create a zip in a staging bucket which represents the release.

### Parameters

- cloudfront - (Optional) If true, adds cloudfront invalidation to the buildspec.

## codebuild/environmentVars/copy-s3-to-s3.yaml.erb

Environment variables for the buildspec of the same name.

### Parameters

- dest - The name of the detination S3 bucket.
- cloudfrontLogicalId - (Optional) The logical ID of the cloudfront distribution. Required for cloudfront invalidations.

## codebuild/environmentVars/static-website.yaml.erb

Environment variables for the buildspec of the same name.

### Parameters

- appBucket - The name of the S3 bucket which hosts the website.
- stagingBucket - The name of the S3 bucket which will store the release zip.
- cloudfrontLogicalId - (Optional) The logical ID of the cloudfront distribution. Required for cloudfront invalidations.

## codebuild/s3-upload-from-s3.yaml.erb

Creates a codebuild project which uses an S3 bucket as its source.

## Cloudformation Parameters

- ProjectName

### Parameters

- id - The logical ID of the codebuild resource.
- source - The name of the source S3 bucket.
- buildSpec - The path of the buildspec erb to use.
- environmentVars - The path of the environment variables erb to use.
- role - The logical ID of a role resource for the codebuid project to assume.
- tag - The environment tag.

## codebuild/s3-upload.yaml.erb

Creates a codebuild project which uses an S3 bucket as its source.

### Cloudformation Parameters

- ProjectName

### Parameters

- id - The logical ID of the codebuild resource.
- source - The name of the source S3 bucket.
- buildSpec - The path of the buildspec erb to use.
- environmentVars - The path of the environment variables erb to use.
- role - The logical ID of a role resource for the codebuid project to assume.
- tag - The environment tag.

## codecommit/repository.yaml.erb

Creates a codecommit repository.

### Parameters

- id - The logical ID of the codecommit repository resource.
- name - The name of give the new repository.
- description - A brief description of what will be in the repository.
- triggers - (Optional) A collection of triggers to apply to the repository.
