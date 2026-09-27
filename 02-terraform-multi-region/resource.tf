resource "aws_s3_bucket" "india" {
  bucket = "terraform-multi-region-india-example"
}

resource "aws_s3_bucket" "usa" {
  provider = aws.us_east_1

  bucket = "terraform-multi-region-usa-example"
}