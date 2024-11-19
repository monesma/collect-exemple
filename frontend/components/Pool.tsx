'use client'
import { useState, useEffect } from "react"
//récup les infos sur le wallet connecté
import { Alert, AlertIcon } from "@chakra-ui/react"
import Contribute from "./Contribute"
import Progression from "./Progression"
import Refund from "./Refund"
import { useAccount, usePublicClient, useReadContract, useWatchContractEvent } from "wagmi"
"@wagmi/core"
import { contractAddress, abi } from "@/constants"
import { Contributor } from "@/types"
import { parseAbiItem, Log } from "viem"
import Contributors from "./Contributors"

export const Pool = () => {

    const client: any = usePublicClient()

    const { address, isConnected } = useAccount()

    const [end, setEnd] = useState<string>("")
    const [goal, setGoal] = useState<string>("")
    const [totalCollected, setTotalCollected] = useState<string>("")
    const [isLoading, setIsLoading] = useState<boolean>(true)
    const [events, setEvents] = useState<Contributor[]>([])
    const { data } =  useReadContract({
        abi,
        address: contractAddress,
        functionName: 'end',
      })

    const  data2 =  useReadContract({
        abi,
        address: contractAddress,
        functionName: 'goal',
    })

    const  data3 =  useReadContract({
        abi,
        address: contractAddress,
        functionName: 'totalCollected',
    })
    
    const getData = async () => {
        if(isConnected){
            const myDate: any = await data?.toString()
            let date = new Date(parseInt(myDate) * 1000)
            let day = date.getDate()
            let month = date.getMonth()
            let year = date.getFullYear()
            let endDate: string = `${day}/${month}/${year}`
            setEnd(end)
            
            const myGoal: any = await data2.data?.toString()
            setGoal(myGoal)
            
            const total: any = await data3.data?.toString()
            setTotalCollected(total)
            
            const contributeLogs: any = await client.getLogs({
                address: contractAddress,
                event: parseAbiItem('event Contribute(address indexed contributor, uint256 amount)'),
                fromBlock: 0n,
                toBlock: 'latest'
            })
            setEvents(contributeLogs.map((log: { args: { contributor: string; amount: bigint } }) => ({
                contributor: log.args.contributor as string,
                amount: (log.args.amount as bigint).toString()
            })))
            setIsLoading(false)
        }   
    }

    useEffect(()=>{
        getData()
    }, [client])
    return (
        <>
            {isConnected ? (<>
                <Progression 
                    isLoading={isLoading}
                    end={end}
                    goal={goal}
                    totalCollected={totalCollected}
                />
                <Contribute getDatas={getData} />
                <Refund getDatas={getData} end={end} goal={goal} totalCollected={totalCollected}/>
                <Contributors events={events} />
            </>
            ):(
                <Alert status="warning">
                    <AlertIcon />
                    Please connect your wallet
                </Alert>
            )}
        </>
    )
}
