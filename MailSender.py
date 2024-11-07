import msal
import requests;

#Documentation
#https://learn.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0&tabs=http


dict_ = {'client_id': 'appId', 'secret': 'secret', 'tenant_id': 'tenantId'}

def acquire_token():
    print('Inside acquire_token')
    authority_url = f'https://login.microsoftonline.com/{dict_["tenant_id"]}'
    app = msal.ConfidentialClientApplication(
        authority=authority_url,
        client_id=dict_["client_id"],
        client_credential=dict_["secret"]
    )
    token = app.acquire_token_for_client(scopes=["https://graph.microsoft.com/.default"])
    print('token',token)
    return token

result = acquire_token()

if "access_token" in result:
    print("Access token created.",result["access_token"])

if "access_token" in result:
    #endpoint = f'https://graph.microsoft.com/v1.0/users/amit9415_gmail.com#EXT#@amit9415gmail.onmicrosoft.com/sendMail'
    endpoint = f'https://graph.microsoft.com/v1.0/amit9415@gmail.com/sendMail'
    toUserEmail = "neharulz16@gmail.com"  
    email_msg = {'Message': {'Subject': "Meet for lunch?",
                            'Body': {'ContentType': 'Text', 'Content': "The new cafeteria is open."},
                            'ToRecipients': [{'EmailAddress': {'Address': toUserEmail}}]
                            },
                'SaveToSentItems': 'true'}
    
    r = requests.post(endpoint,headers={'Authorization': 'Bearer ' + result['access_token']},json=email_msg)
    if r.ok:
        print('Sent email successfully')
    else:
        print(r.json())