resource "aws_ecr_repository" "base-emrs" {
    name                 = "emr-serverless"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = false
    }
}

resource "aws_ecr_repository_policy" "emrs-policy" {
    repository = aws_ecr_repository.base-emrs.name
    policy     = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "Emr Serverless Custom Image Support",
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "emr-serverless.amazonaws.com"
                    },
                    "Action": [
                        "ecr:BatchGetImage",
                        "ecr:DescribeImages",
                        "ecr:GetDownloadUrlForLayer"
                    ]
                }
            ]
        }
    )
}



resource "aws_ecr_repository" "mlflow" {
    name                 = "mlflow"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = false
    }
}

resource "aws_ecr_repository_policy" "emrs-policy" {
    repository = aws_ecr_repository.mlflow.name
    policy     = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "ECRRepositoryPolicy",
                    "Effect": "Allow",
                    "Principal": {
                        "AWS": [
                            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*",
                            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/*"
                        ]
                    },
                    "Action": [
                        "ecr:DescribeImages",
                        "ecr:DescribeRepositories"
                    ]
                }
            ]
        }
    )
}