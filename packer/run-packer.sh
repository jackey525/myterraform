packer build \
  -var 'aws_access_key=' \
  -var 'aws_secret_key=' \
  -var 'aws_region=ap-northeast-1' \
  -var 'aws_base_ami=ami-0278fe6949f6b1a06' \
  ami.json