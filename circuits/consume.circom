pragma circom 2.0.6;

include "../node_modules/keccak-circom/circuits/keccak.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template CREATE2Address() {
    signal input deployingAddress;
    signal input salt;
    signal input bCodeHash;
    
    signal output address;
    
    // 0xff + 20-byte address + 32-byte salt + 32-byte init code hash
    var inLength = 1 + 20 + 32 + 32; // 85 bytes
    
    var addressLength = 12;
    
    var i;
    var offset = 0;
    
    component keccak256 = Keccak(inLength * 8, 256);
    
    for(i = 0; i < 8; i++) {
        keccak256.in[i] <== 1; // 0xff
    }
    offset = i;
    
    component deployingAddressBits = Num2Bits(20*8); // 20-byte address
    deployingAddressBits.in <== deployingAddress;
    for(i=i; i < offset + 160; i++) {
        keccak256.in[i] <== deployingAddressBits.out[i - offset];
    }
    offset = i;
    
    component saltBits = Num2Bits(32*8); // 32-byte salt
    saltBits.in <== salt;
    for(i=i; i < offset + 256; i++) {
        keccak256.in[i] <== saltBits.out[i - offset];
    }
    offset = i;
    
    component bCodeHashBits = Num2Bits(32*8); // 32-byte init code hash
    bCodeHashBits.in <== bCodeHash;
    for(i=i; i < offset + 256; i++) {
        keccak256.in[i] <== bCodeHashBits.out[i - offset];
    }
    
    component addressGen = Bits2Num(addressLength * 8);
    for(i = 0; i < addressLength * 8; i++) {
        addressGen.in[i] <== keccak256.out[i];
    }
    
    address <== addressGen.out;
}

template Consume() {
    signal input deployingAddress;
    signal input bCodeHash;
    
    signal input secret;
    
    signal input extDataHash;
    
    signal output address;
    
    component salt = Poseidon(1);
    salt.inputs[0] <== secret;

    component contractAddress = CREATE2Address();
    contractAddress.deployingAddress <== deployingAddress;
    contractAddress.salt <== salt.out;
    contractAddress.bCodeHash <== bCodeHash;
    
    address <== contractAddress.address;
    
    signal extDataSquare <== extDataHash * extDataHash;
}

component main { public [extDataHash] } = Consume();
