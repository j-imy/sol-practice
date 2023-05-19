// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract Soil{
    address private owner;
    uint256 _fieldCounter;
    uint256 _createFees = 0.001 ether;

    mapping(address => bool) _authorities;

    constructor(){
        owner = msg.sender;
        _fieldCounter = 0;
        _authorities[msg.sender] = true;
    }

    // Final Approved Field By Trusted Authority | Needs to be verified first
    struct Field{
        uint256 fieldId;
        string metadataURI;
        uint256 price;
        bool isListedForSale;
        bool isVerified;
    }

    mapping(uint256 => address) private _fieldOwner;
    mapping(uint256 => Field) private _fields;

    modifier checkVerified(uint256 _fieldId) {
        require(_fields[_fieldId].isVerified, "This field is not yet verified!");
        _;
    }

    modifier checkOwnership(uint256 _fieldId) {
        require(_fieldOwner[_fieldId] == msg.sender, "You are not allowed for this action!");
        _;
    }

    modifier checkIsListed(uint _fieldId){
        require(_fields[_fieldId].isListedForSale, "This field is not for sale!");
        _;
    }

    modifier checkValidFees(){
        require(msg.value > _createFees, "Unsufficient Fees, This should be atleast 0.001 ether!");
        _;
    }

    function ownerOf(uint256 _fieldId) public checkVerified(_fieldId) view returns (address){
        require(_fields[_fieldId].isVerified == true, "This field is not yet verified!");
        return _fieldOwner[_fieldId];
    }

    function getFieldCounter() public view returns (uint256){
        return _fieldCounter;
    }

    function transferEther(uint256 _value, address beneficiery) private {
        (bool sent2, ) = beneficiery.call{value: _value}("");
        require(sent2, "Failed to send Ether");
        return;
    }

    function getFieldById(uint256 _fieldId) public checkVerified(_fieldId) view returns(Field memory field){
        return _fields[_fieldId];
    }

    function applyForField(string memory _metadataURI, uint256 _price) public checkValidFees payable returns(uint256) {
        Field memory newField = Field({
            fieldId: _fieldCounter,
            metadataURI: _metadataURI,
            price: _price,
            isListedForSale: false,
            isVerified: false
        });

        _fields [_fieldCounter] = newField;
        _fieldOwner [_fieldCounter] = msg.sender;

        transferEther(_createFees, owner);

        return _fieldCounter++;
    }

    function addAuthority(address _authority) public returns(bool){
        require(msg.sender == owner, "You are not allowed for this action!");
        _authorities[_authority] = true;
        return true;
    }

    function changeVerifyField(uint256 _fieldId, bool status) public returns(bool){
        require(_authorities[msg.sender], "You are not allowed for this action!");
        require(!_fields[_fieldId].isVerified, "This field is already verified!");
        // if verify or unverify
        if(status){
            _fields[_fieldId].isVerified = true;
        }
        else{
            delete _fields[_fieldId];
        }
        return true;
    }

    function listFieldForSale(uint256 _fieldId) public checkVerified(_fieldId) checkOwnership(_fieldId) returns(bool){
        require(!_fields[_fieldId].isListedForSale, "This field is already listed for sale!");
        _fields[_fieldId].isListedForSale = true;
        return true;
    }

    function unListFieldForSale(uint256 _fieldId) public checkVerified(_fieldId) checkOwnership(_fieldId) returns(bool){
        require(_fields[_fieldId].isListedForSale, "This field is already unListed for sale!");
        _fields[_fieldId].isListedForSale = false;
        return true;
    }

    function executeSale(uint256 _fieldId) public checkVerified(_fieldId) checkIsListed(_fieldId) checkValidFees payable returns(bool){
        require(msg.value >= _createFees + _fields[_fieldId].price, "Unsufficient Amount, This should be atleast 0.001 ether + Price Of Field!");
        _fields[_fieldId].isListedForSale = false;

        transferEther(_createFees, owner);
        transferEther(_fields[_fieldId].price, _fieldOwner[_fieldId]);

        _fieldOwner [_fieldId] = msg.sender;

        return true;
    }

    function updateFieldPrice(uint256 _fieldId, uint256 _price) public checkVerified(_fieldId) checkOwnership(_fieldId) returns(bool) {
        _fields[_fieldId].price = _price;
        return true;
    }

    function getAdressFields(address _owner) public view returns(Field[] memory){
        require(msg.sender == _owner || _authorities[msg.sender], "You are not authorized for this action!");
        uint256 _fieldItemCount = 0;
        for(uint256 i = 0; i < _fieldCounter; i++){
            if(_fieldOwner[i] == _owner){
                _fieldItemCount += 1;
            }
        }

        Field[] memory _fieldItems = new Field[](_fieldItemCount);
        _fieldItemCount = 0;
        for(uint256 i = 0; i < _fieldCounter; i++){
            if(_fieldOwner[i] == _owner){
                _fieldItems[_fieldItemCount] = _fields[i];
                _fieldItemCount += 1;
            }
        }

        return _fieldItems;
    }

    function getAllFields() public view returns(Field[] memory){
        Field[] memory _fieldItems = new Field[](_fieldCounter);

        for(uint256 i = 0; i < _fieldCounter; i++){
            _fieldItems[i] = _fields[i];
        }

        return _fieldItems;
    }

    function getUnVerifiedFields() public view returns(Field[] memory){
        uint256 _fieldItemCount = 0;
        for(uint256 i = 0; i < _fieldCounter; i++){
            if(!_fields[i].isVerified){
                _fieldItemCount += 1;
            }
        }

        Field[] memory _fieldItems = new Field[](_fieldItemCount);
        _fieldItemCount = 0;
        for(uint256 i = 0; i < _fieldCounter; i++){
            if(!_fields[i].isVerified){
                _fieldItems[_fieldItemCount] = _fields[i];
                _fieldItemCount += 1;
            }
        }

        return _fieldItems;
    }

    function getVerifiedFields() public view returns(Field[] memory){
        uint256 _fieldItemCount = 0;
        for(uint256 i = 0; i < _fieldCounter; i++){
            if(_fields[i].isVerified){
                _fieldItemCount += 1;
            }
        }

        Field[] memory _fieldItems = new Field[](_fieldItemCount);
        _fieldItemCount = 0;
        for(uint256 i = 0; i < _fieldCounter; i++){
            if(_fields[i].isVerified){
                _fieldItems[_fieldItemCount] = _fields[i];
                _fieldItemCount += 1;
            }
        }

        return _fieldItems;
    }
}
