from netmiko import ConnectHandler,redispatch
import time

def ssh_connection(IP_address, username, password, device_type = 'arista_eos', ssh_config_file = None):
    """Return connection object to the device using netmiko.

    if ssh_config_file is provided then only it will use ssh proxy otherwise it will not.
    """
    connection_paramaters_dict = {
        'device_type' : device_type,
        'ip' : IP_address,
        'username' : username,
        'password' : password,
    }

    if ssh_config_file is not None:
        connection_paramaters_dict[ 'ssh_config_file' ] = ssh_config_file

    connection = ConnectHandler(**connection_paramaters_dict)

    return connection


if __name__ == '__main__':
    #con_obj = ssh_connection('192.168.1.2', 'vagrant', 'vagrant' )
    #testing to connect using jumphost
    con_obj = ssh_connection('192.168.1.1', 'username','password', 'linux' )
    print ('SSH prompt: {}'.format(con_obj.find_prompt()))
    con_obj.write_channel('ssh automation@192.168.200.202\n')
    time.sleep(1)
    output = con_obj.read_channel()
    if 'ssword' in output:
        con_obj.write_channel('secondary_password' + '\n')
    time.sleep(1)
    output += con_obj.read_channel()
    print(output)
    # redispatching to cisco_ios
    redispatch(con_obj, device_type = 'cisco_ios')

    output = con_obj.send_command('sh process cpu history')
    print (output)
