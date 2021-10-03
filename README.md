# terraform-first 03/10/2021
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
		
<img src="https://github.com/ktmtwm/terraform-first/blob/master/results/output.png" width=400>

### View Nginx server with:
##### * Home page:
		http://<public_ip>
		
<img src="https://github.com/ktmtwm/terraform-first/blob/master/results/nginxHello.png" width=400>

##### * Resource usage page:	(Realtime refresh)
		http://<public_ip>/resource.html
		
<img src="https://github.com/ktmtwm/terraform-first/blob/master/results/resource.png" width=400>

##### * Health check page:	(Realtime refresh)
		http://<public_ip>/health.html
		
<img src="https://github.com/ktmtwm/terraform-first/blob/master/results/health.png" width=400>

##### * Nginx root page words calculate:
		http://<public_ip>/words.html
		
<img src="https://github.com/ktmtwm/terraform-first/blob/master/results/words.png" width=400>

