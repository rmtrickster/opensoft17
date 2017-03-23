pragma solidity ^0.4.0;

contract functionality{
    
    struct Image{
        string latitude;
        string longitude;
        string hash;
        uint tag;
        address userid;
    }

    uint private globalIndex;
    uint private size_data;
    mapping (uint => Image) data;
    
    function functionality(){
        size_data = 0;
        globalIndex = 0;
    }

    function string_equal(string _a, string _b) constant returns (bool) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        
        if (a.length != b.length)
          return false;
          
        for (uint i=0; i<a.length; i++)
          if (a[i] != b[i])
            return false;
            
        return true;
    }

    function strConcat(string _a, string _b,string _c) constant returns (string _result){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        return string(babcde);
    }
    
    function cordinate_convert(string cordinates) constant returns (uint[2] result){
        bytes memory str = bytes(cordinates);
        uint str_size = str.length;
        
        uint before_dec;
        uint after_dec;
        uint status;
        
        status = 0;
        before_dec = 0;
        after_dec = 0;
        uint[2] memory int_cords;
        
        for (uint i=0; i<str_size; i++){
            if(str[i]=='.'){
                status=1;
                continue;
            }
            if(status==0){
                before_dec *= 10;
                before_dec += uint(str[i])-48;
            }
            else{
                after_dec *= 10;
                after_dec += uint(str[i])-48;
            }
        }
        
        int_cords[0] = before_dec;
        int_cords[1] = after_dec;
        
        result[0] = int_cords[0];
        result[1] = int_cords[1];
    }
    
    // returns 1 if c1>c2, 0 for c1==c2 and 2 if c1<c2
    function compare_cordinates(uint[2] c1, uint[2] c2) constant returns (uint result){ 
        uint num;
        if(c1[0]>c2[0])
            num = 1;
        else if(c1[0]==c2[0]){
            if(c1[1]>c2[1])
                num = 1;
            else if(c1[1]==c2[1])
                num = 0;
            else    
                num = 2;
        }    
        else 
            num = 2;
        result = num;
    }

    function binary_search_back( string lat1) constant returns (uint result){
        uint[2] memory search_lat = cordinate_convert(lat1);

        uint start = 0;
        uint end = size_data-1;
        uint mid = 0;
        uint status;
        uint[2] memory elem_lat;
        uint[2] memory new_elem;

        while(start<end && start<size_data && end>=0){
            mid = (start+end)/2;
            elem_lat = cordinate_convert(data[mid].latitude);
            
            status = compare_cordinates(elem_lat,search_lat);
            if(status == 1){
                end = mid-1;
            }
            else if(status == 2){
                start = mid+1;
            }
            else{
                break;
            }
        }

        uint i;
        for(i=mid-1; i>=0; i--){
            new_elem = cordinate_convert(data[i].latitude);
            if(compare_cordinates(new_elem,elem_lat)!=0)
                break;
        }

        i++;
        result = i;
    }

    function binary_search_forward( string lat1) constant returns (uint result){
        uint[2] memory search_lat = cordinate_convert(lat1);

        uint i;
        uint start = 0;
        uint end = size_data-1;
        uint mid = 0;
        uint status;
        uint[2] memory elem_lat;
        uint[2] memory new_elem;

        while(start<end && start<size_data && end>=0){
            mid = (start+end)/2;
            elem_lat = cordinate_convert(data[mid].latitude);
            
            status = compare_cordinates(elem_lat,search_lat);
            if(status == 1){
                end = mid-1;
            }
            else if(status == 2){
                start = mid+1;
            }
            else{
                break;
            }
        }

        for(i=mid+1; i<size_data; i++){
            new_elem = cordinate_convert(data[i].latitude);
            if(compare_cordinates(new_elem,elem_lat)!=0)
                break;
        }

        i--;
        result = i;
    }
    
    function range_search( string lat1, string long1, string lat2, string long2) constant returns (string result){
        uint[2] memory search_long1 = cordinate_convert(long1);
        uint[2] memory search_long2 = cordinate_convert(long2);

        uint starting = binary_search_back(lat1);
        uint ending = binary_search_forward(lat2);

        uint[2] memory new_elem;
        for(uint j=starting; j<=ending; j++){
            new_elem = cordinate_convert(data[j].longitude);
            
            if(compare_cordinates(new_elem,search_long1)==1){
                if(compare_cordinates(new_elem,search_long2)==2)
                  result = strConcat(result," ",data[j].hash);
            }   
        }
        return result;
    }

    function direct_search( string lat, string lon) constant returns (string result){
        uint[2] memory search_lat = cordinate_convert(lat);
        uint[2] memory search_long = cordinate_convert(lon);

        uint i = binary_search_back(lat);

        uint[2] memory new_elem;
        for(uint j=i; j<size_data; j++){
            new_elem = cordinate_convert(data[j].latitude);
            if(compare_cordinates(new_elem,search_lat)!=0)
                break;

            new_elem = cordinate_convert(data[j].longitude);
            if(compare_cordinates(new_elem,search_long)==0){
                result = strConcat(result," ",data[j].hash);
            }    
        }

        return result;
    }

    function insert_elem( string lat) {
        uint index;
        if(size_data > 0){
            index = binary_search_forward(lat);
            index++;
            for(uint i=size_data; i>index; i--)
                data[i] = data[i-1];
        }
        else{
            index = 0;
        }
        size_data++;
        data[index].latitude = lat;
        globalIndex = index;
    }

    function insert_elem2( string lon, string hash) {
        data[globalIndex].longitude = lon;
        data[globalIndex].hash = hash;
    }

    function insert_elem3( uint tag) {
        data[globalIndex].tag = tag;
        data[globalIndex].userid = msg.sender;
    }

    function delete_elem( string hash){
        uint i;
        for(i=0; i<size_data; i++){
            if(string_equal(data[i].hash,hash)){
                delete data[i];
                break;
            }
        }
        for(uint j=i+1; j<size_data; j++){
            data[j-1] = data[j];
        }
        size_data--;
    }


    function incr_size(){
        size_data++;
    }

    function show_entries() constant returns (string result) {
        for(uint i=0; i<size_data; i++){
            result = strConcat(result," ",data[i].hash);
        }
    }

    function return_size() constant returns (uint result){
        result = size_data;
    }

    function return_firstele() constant returns (string){
        return data[0].hash;
    }
}