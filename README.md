## **简介**

Beehome 为 docker虚机管理系统，用来管理 alpha测试和性能测试过程中所需的虚拟机。

## **注意事项**

+ 每台物理设备需提前准备好 docker 运行环境。
+ 采用了公司定制的 docker，能够直接设置 IP 地址。

## **API 说明**

### **申请alpha测试机**

我们为alpha测试虚机提供统一的cpu及memory配置。

```
GET 'api/v1/containers/apply_random_containers'
```

Parameters:

+ `number` (required) - 虚机的个数
+ `purpose` (required) - 虚机的用途，如 'alpha' 

Return:

+ `{result: 0, message: "Failed.No free container with recommended image."}`
+ `{result: 0, message: "Less than the request numer."}`
+ `{result: 1, message: "Successfully.", purpose: 'alpha', ip_addresses: ip_addresses}`

### **初始化alpha测试机**

alpha测试机被释放后，为了下次的测试有良好的运行环境，可以通过该接口初始化测试机。

```
POST 'api/v1/containers/rebuild_a_container'
```

Parameters:

+ `ip` (required) - 虚机的 IP 地址
+ `return_url` (required) - 初始化结束后，回调的 url

Return:

+ `{result: 0, message: "Failed.No such ip record in ip_addresses table."}`
+ `{result: 0, message: "Failed.No container with the specified ip in containers table."}`
+ `{result: 1, message: "Beehome is going to rebuild the container with ip #{container_ip} !`

Callback结果：
+ `{"result" => false, "message" => "{"result" => false,"message" => "[warning] The container once was deleted before."} }`
+ `{"result" => false, "message" => "[warning] There's none recommended image for #{to_be_deleted_container.image.purpose} purpose."}`
+ `{"result" => true, "message" => to_be_deleted_container.ip_address.address}`


### **申请特殊配置的虚机**

性能测试所需的虚机，要求特定的cpu个数与内存，可以通过该接口申请特殊的设备。

```
POST 'api/v1/containers/apply_special_containers'
```

Parameters:
```json
{
  "purpose" => "performance_test",
  "machines" => [
                  {
                    "id" => "001",
                    "processor_size" => 2,
                    "processor_occupy_mode" => "private",
                    "memory_size" => 4,
                  },
                  {
                    "id" => "002",
                    "processor_size" => 4,
                    "processor_occupy_mode" => "share",
                    "memory_size" => 4,
                  }
                ],
  "return_url" => "http://ci-server/.../..."
}
```

Return:

+ `{result: 0, message: "No params error!"}`
+ `{result: 0, message: "No return_url error!"}`
+ `{result: 0, message: "No purpose error!"}`
+ `{result: 0, message: "No machiens error!"}`
+ `{result: 1, message: "Beehome is going to provide the containers !"}`

Callback结果：

+ `{"result"=>true, "message"=>[{"001"=>"192.168.7.15"},{"002"=>"192.168.7.15"}]}`
+ `{"result"=>false, "message"=>"No device can provide 2 processors and 4G memory."]`

### **删除性能测试虚机**

性能测试结束后，要把申请到的虚机删除掉。

```
POST 'api/v1/containers/delete_containers'
```

Parameters:

+ `ips` (required) - 多个被删除虚机的IP，用逗号分隔 。如‘192.168.78.187,192.168.78.190,192.168.78.100’
+ `purpose` (required) - 被删虚机的用途。如‘performance_test’ 或‘jagent’
+ `return_url` (required) - 回调的 url 。

Return:

+ `{result: 0, message: "Failed.No such ip #{container_ip} record in ip_addresses table."}`
+ `{result: 0, message: "Failed.No container with the specified ip in containers table."}`
+ `{result: 1, message: "Beehome is going to delete the containers !"}`

Callback结果：

+ `{"result"=>false, "message"=>[{"id"=>1002, "state"=>"true"}, {"id"=>1003, "state"=>"false"}]}`
+ `{"result"=>true, "message"=>[{"id"=>1002, "state"=>"true"}, {"id"=>1003, "state"=>"true"}]}`
