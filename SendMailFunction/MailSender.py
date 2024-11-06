import logging 
import azure.functions as func 
import requests 
from msal import ConfidentialClientApplication 

  

def main(req: func.HttpRequest) -> func.HttpResponse: 

    logging.info('Python HTTP trigger function processed a request.') 

  

    client_id = "your-client-id" 

    client_secret = "your-client-secret" 

    tenant_id = "your-tenant-id" 

    authority = f"https://login.microsoftonline.com/{tenant_id}" 

    scope = ["https://graph.microsoft.com/.default"] 

  

    app = ConfidentialClientApplication( 

        client_id, 

        authority=authority, 

        client_credential=client_secret 

    ) 

  

    result = app.acquire_token_for_client(scopes=scope) 

  

    if "access_token" in result: 

        email_payload = { 

            "message": { 

                "subject": "Test Email", 

                "body": { 

                    "contentType": "Text", 

                    "content": "This is a test email sent from the Microsoft Graph API." 

                }, 

                "toRecipients": [ 

                    { 

                        "emailAddress": { 

                            "address": "<a href="mailto:recipient@example.com">recipient@example.com</a>" 

                        } 

                    } 

                ] 

            } 

        } 

  

        response = requests.post( 

            "https://graph.microsoft.com/v1.0/me/sendMail", 

            headers={"Authorization": "Bearer " + result['access_token'], "Content-Type": "application/json"}, 

            json=email_payload 

        ) 

  

        if response.status_code == 202: 

            return func.HttpResponse("Email sent successfully!", status_code=200) 

        else: 

            return func.HttpResponse(f"Failed to send email: {response.status_code} {response.text}", status_code=500) 

    else: 

        return func.HttpResponse("Failed to acquire token.", status_code=500) 

 