# SMS-blockchain-relay-project
“Broadcast transactions to StarkNet via SMS”        
                                                              
- User with simple feature phone can send/receive value.

- Utilizes a known sms relay(So relay is Android app receiving incoming sms, and processes payload, then constructs a signed transaction and broadcasts)

- Anyone can set up an sms relay and allow their contacts to transmit sms to their phone, relay then parses payload
  
This ideas borrows heavily from a local startup which has implemented the same for other blockchains (Celo and Stellar)  https://twitter.com/CeloOrg/status/1519382764537143296. 
Building it on Starknet.    
