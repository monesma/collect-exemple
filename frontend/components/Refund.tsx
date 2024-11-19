'use client'

import { Flex, Text, Input, Button, Heading, useToast } from "@chakra-ui/react"
import { contractAddress, abi } from "@/constants"
import { RefundProps } from "@/types"
import { parseEther } from "viem"
import { createConfig, http, useWriteContract, useWaitForTransactionReceipt  } from 'wagmi'
import { useEffect } from "react"


const Refund = ({ getDatas, end, goal, totalCollected }: RefundProps) => {
  const toast = useToast()

  const { data: hash, writeContract } = useWriteContract() 

  const recup = async (e: any) => {
    try {
       
        e.preventDefault()
        await writeContract({
            address: contractAddress,
            abi: abi,
            functionName: 'refund',
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
            getDatas()
            toast({
                title: 'Congratulations',
                description: "Your have been refunding.",
                status: 'success',
                duration: 4000,
                isClosable: true,
            })
        }
    }, [isConfirmed])

  return (
    <>
        <Heading mt='2rem'>Refund</Heading>
            <Flex mt="1rem">
                {totalCollected < goal && Math.floor(Date.now() / 1000) > parseInt(end) ? (
                    <Button 
                        colorScheme='red' 
                        size='lg'
                        width="100%"
                        onClick={(e) => recup(e)}
                    >
                        Refund
                    </Button>
                ) : (
                    <Text color='red'>No refund available right now.</Text>
                )}
            </Flex>
    </>
  )
}

export default Refund