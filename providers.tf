provider "aws"{
    region="us-east-1"
    default_tags {
        tags = {
            Purpose = "CICD Tools"
            Owner   = "DevOps Team"
        }
    }
}