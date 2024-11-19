"use client";
import { Flex, Text, Input, Button, Heading, useToast } from "@chakra-ui/react";
import { useEffect, useState } from "react";
import { contractAddress, abi } from "@/constants"
import { ContributeProps } from "@/types"
import { parseEther } from "viem";
import { createConfig, http, useWriteContract, useWaitForTransactionReceipt  } from 'wagmi'
import { mainnet, sepolia } from '@wagmi/core/chains'

const config = createConfig({
    chains: [mainnet, sepolia],
    transports: {
      [mainnet.id]: http('https://mainnet.example.com'),
      [sepolia.id]: http('https://sepolia.example.com'),
    },
  })

const Contribute = ({getDatas}: ContributeProps) => {

  const toast = useToast()

  const { data: hash, writeContract } = useWriteContract() 

  const [amount, setAmount] = useState<string>("");


  const contribute = async (e: React.FormEvent<HTMLFormElement>) => {
    try {
       
        e.preventDefault()
         //je converti l'ether en wei 10**18
        let money = await parseEther(amount)

        await writeContract({
            address: contractAddress,
            abi: abi,
            functionName: 'contribute',
            value: money
        })
        
    } catch(error){
        console.log(error)
        toast({
            title: 'Error',
            description: "An error occured",
            status: 'error',
            duration: 4000,
            isClosable: true,
        })
    }
  };

  const { isLoading: isConfirming, isSuccess: isConfirmed } = 
    useWaitForTransactionReceipt({ 
      hash, 
    }) 

    useEffect(()=>{
        if(isConfirmed){
            setAmount('')
            getDatas()
            toast({
                title: 'Congratulations',
                description: "Your contribution has been added.",
                status: 'success',
                duration: 4000,
                isClosable: true,
            })
        }
    }, [isConfirmed])
  return (
    <>
      <Heading mt="2rem">Contribute</Heading>
     <form onSubmit={contribute}>
      <Flex mt="1rem">
        <Input name="address" value="0xa0Ee7A142d267C1f36714E4a8F75612F20a79720" type="hidden" />
        <Input
          placeholder="Your amount in ETH"
          size="lg"
          value={amount}
          name="money"
          onChange={(e) => setAmount(e.currentTarget.value)}
        />
        <Button colorScheme="purple" size="lg" type="submit">
            Contribute
        </Button>
      </Flex>
      </form>
      {hash && <div>Transaction Hash: {hash}</div>}
      {isConfirming && <div>Waiting for confirmation...</div>} 
      {isConfirmed && <div>Transaction confirmed.</div>} 
    </>
  );
};

export default Contribute;
