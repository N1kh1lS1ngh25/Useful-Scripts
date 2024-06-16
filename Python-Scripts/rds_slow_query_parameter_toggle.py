                            
# _____ __  _  ________           
# \__  \\ \/ \/ /  ___/  
#  / __ \\     /\___ \ 
# (____  /\/\_//____  >         
#      \/           \/            
################################################################################################
# This script:
# uses the boto3 library to interact with Amazon RDS, and modify the parameters from the attached
# parameter group.
################################################################################################
# Args:
#   -event (dict): Dictionary containing information about the event that triggered the function.
#   -context (LambdaContext): Context information about the invocation, including the function name,
#                             version, and ID.
################################################################################################

import boto3

def describe_and_modify_parameter(param_group_name, param_name):
    client = boto3.client("rds")

    # Initialize marker for pagination
    marker = "String"
    parameters = []

    # Retrieve parameters in multiple steps
    while True:
        # Fetch parameters with marker
        response = client.describe_db_parameters(
            DBParameterGroupName=param_group_name, Marker=marker
        )
        parameters.extend(response["Parameters"])

        # Check if there are more parameters to retrieve
        if "Marker" in response:
            marker = response["Marker"]
        else:
            break

    # Search for the specified parameter
    parameter_value = None
    for parameter in parameters:
        if parameter["ParameterName"] == param_name:
            parameter_value = parameter.get("ParameterValue", "Not set")
            break

    # Print the value of the specified parameter
    if parameter_value is not None:
        print(f"The value of parameter '{param_name}' is '{parameter_value}'.")
    else:
        print(
            f"Parameter '{param_name}' not found in parameter group '{param_group_name}' "
        )

    # Modify the parameter value if it's not already set to '1'
    if parameter_value == "1":
        response = client.modify_db_parameter_group(
            DBParameterGroupName=param_group_name,
            Parameters=[
                {
                    "ParameterName": param_name,
                    "ParameterValue": "0",
                    "ApplyMethod": "immediate",
                },
            ],
        )
        print(
            f"Parameter {param_name} in parameter group {param_group_name} is changed to '0' successfully"
        )
    elif parameter_value == "0":
        response = client.modify_db_parameter_group(
            DBParameterGroupName=param_group_name,
            Parameters=[
                {
                    "ParameterName": param_name,
                    "ParameterValue": "1",
                    "ApplyMethod": "immediate",
                },
            ],
        )
        print(
            f"Parameter {param_name} in parameter group {param_group_name} is changed to '1' successfully"
        )

if __name__ == "__main__":
    param_group_name = "your-parameter-group-name"
    param_name = "slow_query_log"
    describe_and_modify_parameter(param_group_name, param_name)
