import os, time, json, ast

def createPayloud():
    timeNow = time.strftime('%Y-%m-%d %H:%M:%S')
    payloud = {
        "timeStamp" : timeNow + "+00:00",
        "apiVersion": "1.0.0",
        "entity": {
            "id": "0000-00000-0000-1234",
            "type": "Product",
            "name": "Brooklyn",
            "awsRegion": "eu-west-1"
        },
        "healthStatusReport": {
            "globalStatus": 0,
            "reportingServices": [],
            "tenants": [],
            "alarms": {
                "dashboardUrl": "https://alarms.brooklyn.synamedia.com",
                "alarmList": []
            }
        }
    }

    dirs = 'monitoring_files'


    for filename in os.listdir(dirs):
        with open(dirs + '/' + filename) as f:
             deployerInfo = {}
             serviceInstances = []
             for line in f:
                 line = line.strip()
                 x = line.split(' ')
                 if x[0] == 'COMPONENT' :
                     serviceInstances.append({ "instanceId": x[1] +"-0000-0000-0001","status": x[2].split(':')[1],"statusDescription": "Normal operation"})
                 elif x[0] == 'TOTAL' :
                     deployerName = (filename.split('_')[1]).split('.')[0]
                     deployerStatus = (line.split(' ')[1]).split(':')[1]
                     deployerInfo={ "id":deployerName + ":234","name": deployerName,"status": deployerStatus,"serviceInstances":serviceInstances}
        payloud['healthStatusReport']['tenants'].append(deployerInfo)
        print((json.dumps(payloud)).replace("'", '"'))
    return (json.dumps(payloud)).replace("'", '"')

