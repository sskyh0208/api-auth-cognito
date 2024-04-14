up:
	docker compose up -d
down:
	docker compose down
rebuild:
	docker compose up -d --build
destroy:
	docker compose down --rmi all --volumes --remove-orphans
restart:
	docker compose restart
logs:
	docker compose logs -f
ls:
	docker compose ls
ps:
	docker compose ps
terraform:
	docker compose exec terraform bash
create-backend:
	docker compose exec terraform bash scripts/create_terraform_backend.sh
dev-init:
	docker compose exec terraform terraform -chdir=./terraform/environments/dev init
dev-plan:
	docker compose exec terraform terraform -chdir=./terraform/environments/dev plan
dev-apply:
	docker compose exec terraform terraform -chdir=./terraform/environments/dev apply
dev-destroy:
	docker compose exec terraform terraform -chdir=./terraform/environments/dev destroy