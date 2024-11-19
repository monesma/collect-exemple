'use client'
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { Flex, Text } from '@chakra-ui/react';
const Header = () => {
  return (
    <Flex
            p="2rem"
            justifyContent="space-between"
            alignItems="center"
            width="100%"
        >
            <Text as="b">Logo</Text>
            <ConnectButton />
    </Flex>
  )
}

export default Header