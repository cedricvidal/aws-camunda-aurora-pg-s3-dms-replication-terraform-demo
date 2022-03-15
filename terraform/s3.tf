resource "aws_s3_bucket" "dms-target-s3-bucket" {
  bucket = "dms-target-${local.region}"

  tags = {
    Name        = "dms-target-${local.region}"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "dms-target-s3-bucket-acl" {
  bucket = aws_s3_bucket.dms-target-s3-bucket.id
  acl    = "private"
}
