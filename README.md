# terraform-first
### Parameters:

	You may need to change variables in variables.tf
	
##### * credentials.default 
    -> to your own local aws credential path
##### * pemfile.default 
    -> to your own local key path. project will automate save ssh rsa private key.

### Execute with command: 
	terraform init
	terraform plan
	terraform apply
	// terraform destroy

### You will get output of public_id:
	Outputs:
		public_ip = xx.xx.xx.xx
### View Nginx server with:
##### * Home page:
		http://<public_ip>
##### * Resource usage page:	(Realtime refresh)
		http://<public_ip>/resource.html
##### * Health check page:	(Realtime refresh)
		http://<public_ip>/health.html
##### * Nginx root page words calculate:
		http://<public_ip>/words.html

