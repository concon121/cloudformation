# Code Commit Login Options

## SSH

### Steps

1. Generate ssh key: `ssh-keygen`
2. Upload SSH public key to the IAM user: IAM > Users > $user > Security Credentials > Upload SSH public key.
3. Add AWS config to ~/.ssh/config

```
  Host git-codecommit.*.amazonaws.com
  User SSH_KEY_ID
  IdentityFile ~/.ssh/id_rsa
```

Where SSH_KEY_ID is the id in IAM of the ssh key you just uploaded.

### Issues

1. Access to port 22 may be blocked.

## Username and Password

### Steps

1. Navigate to: IAM > Users > $user > Security Credentials
2. Find 'HTTPS Git credentials for AWS CodeCommit' at the bottom of the page.
3. Click 'Generate' and make a note of the generated username and password.

## AWS Credentials Helper

### Pre-Requisites

- Python 2 + pip
- AWS cli

Installation instructions for the AWS cli here: <http://docs.aws.amazon.com/cli/latest/userguide/installing.html>

### Steps

1. Download the samlapi python script: <https://s3.amazonaws.com/awsiammedia/public/sample/SAMLAPICLIADFS/samlapi.py>
2. Install the scripts dependencies with pip:

  ```
  pip install beautifulsoup4 requests-ntlm boto
  ```

3. Add the ~/.aws/credentials file with the following content:

  ```
  [default]
  output = json
  region = eu-west-1
  aws_access_key_id =
  aws_secret_access_key =
  ```

4. Run the samlapi.py script and log in to AD FS.

5. Edit ~/.aws/config and add the following:

  ```
  [profile small-apps]
  role_arn = arn:aws:iam::977855701381:role/cb-codecommit-test
  source_profile = default
  ```

6. Update the git config to use the AWS CLI CodeCommit credential helper:

  ```
  git config --global credential.helper '!aws --profile marketingadmin codecommit credential-helper $@'
  git config --global credential.UseHttpPath true
  ```

### Issues

1. Needs aws security credentials, so will need to programatically log into AD and request AWS STS temporarty credentials.
