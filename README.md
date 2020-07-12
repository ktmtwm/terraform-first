# terraform-first
Execute with command: 
	terraform init
	terraform plan
	terraform apply 
You will get output of public_id:
	Outputs:
		public_ip = xx.xx.xx.xx
View Nginx server with:
	Home page:
		http://<public_ip>
	Resource usage page:	(Realtime refresh)
		http://<public_ip>/resource.html
	Health check page:		(Realtime refresh)
		http://<public_ip>/health.html
	Nginx root page words calculate:
		http://<public_ip>/words.html

terraform destroy