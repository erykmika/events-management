aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker build -t ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/events-management-frontend:latest ./frontend
docker build -t ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/events-management-backend:latest ./backend

docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/events-management-frontend:latest
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/events-management-backend:latest
