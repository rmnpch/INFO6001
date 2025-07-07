# -*- coding: utf-8 -*-
"""Assessment 1 INFO6001"""

import hashlib
import time

class Block:
    def __init__(self, index, previous_hash, timestamp, data, proof):
        self.index = index
        self.previous_hash = previous_hash
        self.timestamp = timestamp
        self.data = data
        self.proof = proof
        self.hash = self.calculate_hash()

    def calculate_hash(self):
        # Hint: Combine all block attributes into a string and hash it using SHA-256
        combined_block_data = ''
        for attribute, value in self.__dict__.items():
            if attribute != 'hash':
                combined_block_data += str(value)

        encoded_data = combined_block_data.encode('utf-8')
        m = hashlib.sha256()
        m.update(encoded_data)
        return m.hexdigest()
    
    
        
class Blockchain:
    def __init__(self):
        self.chain = [self.create_genesis_block()]
        self.difficulty = 4  # Number of leading zeros required in the hash

    def create_genesis_block(self):
        block = Block(
            index=0,
            previous_hash="0",
            timestamp=time.time(),
            data="Genesis Block",
            proof=0
        )
        return block

    def get_latest_block(self):
        if len(self.chain)<=0:
            return 'List empty'
        return self.chain[-1]

    def add_block(self, new_block):
        # Hint: Set the new block's previous_hash to the hash of the latest block
        self.chain.append(new_block)
        return self.chain
    
    def proof_of_work(self, block):
        # Hint: Increment the proof value until the block's hash starts with the required number of leading zeros
        block.proof = 0
        while not block.hash.startswith('0' * self.difficulty):
            block.proof += 1
            block.hash = block.calculate_hash()
        return block.proof

    def add_data(self, data):
        new_block = Block(
            index=self.get_latest_block().index+1,
            timestamp=time.time(),
            data=data,
            previous_hash=self.get_latest_block().hash, 
            proof=0
            )
        self.proof_of_work(new_block)
        self.add_block(new_block)
        
        return new_block
        
    def is_chain_valid(self):
        # Hint: Check that each block's hash is correct and that the previous_hash matches the hash of the previous block
        for i in range(1, len(self.chain)):
            if (self.chain[i-1].hash != self.chain[i].previous_hash): #Checks if previous hash matches current previous_hash
                return False
            if (self.chain[i].hash != self.chain[i].calculate_hash() ): #Checks if it matched with the hashing calculation and with next item
                return False
            if (not self.chain[i].hash.startswith('0'*self.difficulty)): #Checks if difficulty parameter is met
                return False
        return True

# Example Usage
if __name__ == "__main__":
    blockchain = Blockchain()

    print("Mining block 1...")
    blockchain.add_data("Transaction data for Block 1")

    print("Mining block 2...")
    blockchain.add_data("Transaction data for Block 2")

    print("\nBlockchain validity:", blockchain.is_chain_valid())

    for block in blockchain.chain:
        print(f"Block {block.index} | Hash: {block.hash} | Previous Hash: {block.previous_hash}")