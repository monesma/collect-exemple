'use client'
import { ProgressionProps } from '@/types'
import { contractAddress, abi } from "@/constants"
import { useState, useEffect } from 'react'
import { useAccount } from 'wagmi'
import { Text, Progress, Heading, Spinner } from '@chakra-ui/react'
import { formatEther } from 'viem'

const Progression = ({ isLoading, end, goal, totalCollected }: ProgressionProps) => {
  const { address, isConnected } = useAccount()
  console.log(isLoading, end, goal, totalCollected) 
  return (
    <>
      {isLoading ? <Spinner /> : (
        <>
          <Heading mb="1rem">Progression</Heading>
          <Text mb=".5rem">
            <Text as='span' fontWeight="bold">End date: </Text>{end}
          </Text>
          <Progress
            colorScheme={(parseInt(totalCollected)/parseInt(goal))* 100 < 100 ? "red" : "green"}
            height="32px"
            value={(parseInt(totalCollected)/parseInt(goal))* 100}
            hasStripe
          />
          <Text mt=".5rem">
            {Number(formatEther(BigInt(totalCollected))).toFixed(2)} ETH / {Number(formatEther(BigInt(goal))).toFixed(2)} ETH | <Text as="span" fontWeight="bold">
              {((parseFloat(totalCollected) / parseFloat(goal)) * 100).toFixed(2)} %
            </Text>
          </Text>
        </>
      )}
    </>
  )
}

export default Progression