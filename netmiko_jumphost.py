from netmiko import ConnectHandler,redispatch
#from st2common.runners.base_action import Action
import time

class NetmikoSshLoginDeviceAction(object):
    """docstring for NetmikoSshLoginDeviceAction."""
#    def __init__(self):
#        super(NetmikoSshLoginDeviceAction, self).__init__()

    def run(self, host, username, password, device_type = 'arista_eos', jumphost = False ):
          return self.execute_command(host, username, password, device_type, jumphost)

    def netmiko_ssh_login_device(self, ip, username, password, device_type):
        connection_paramaters_dict = {
                    'device_type' : device_type,
                    'ip' : ip,
                    'username' : username,
                    'password' : password,
        }

        connection = ConnectHandler(**connection_paramaters_dict)
        return connection

    def netmiko_ssh_login_device_with_jumphost(self, ip, username, password, device_type):
        """This function use cdo lab server for testing

        """
        con_obj = self.netmiko_ssh_login_device('jumphost_1_ip', 'username1', 'Passowrd1', 'linux' )
        print ('SSH prompt: {}'.format(con_obj.find_prompt()))
        con_obj.write_channel('ssh automation@192.168.200.202\n')
        time.sleep(1)
        output = con_obj.read_channel()
        if 'ssword' in output:
                con_obj.write_channel(password + '\n')
        time.sleep(1)
        output += con_obj.read_channel()
        print(output)

        redispatch(con_obj, device_type = 'cisco_ios')

        #return object with jumphost in it
        return con_obj
    def execute_command(self, ip, username, password, device_type, jumphost):
        if jumphost:
            print("Inside jumphost clause" + '\n')
    #           try:
            device_cursor = self.netmiko_ssh_login_device_with_jumphost(ip, username, password, device_type)
            print ("got the connection")
            output = device_cursor.send_command('sh version')
            print (output)
            return True, output
    #           except Exception as err:
    #               return False, {'Unknown error has occurred', err}
        else:
            print("without jumphost")
    #           try:
            device_cursor = self.netmiko_ssh_login_device(ip, username, password, device_type)
            print ("got the connection")
            output = device_cursor.send_command('sh version')
            print (output)
            return True, output
    #          except Exception as err:
    #               return False, {'Unknown error has occurred', err}
        return True, output


if __name__ == '__main__':
    run('192.168.1.1', 'username', 'password', jumphost=True)
