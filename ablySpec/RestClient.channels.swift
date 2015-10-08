//
//  RestClient.channels.swift
//  ably
//
//  Created by Yavor Georgiev on 21.08.15.
//  Copyright (c) 2015 г. Ably. All rights reserved.
//

import Nimble
import Quick
import ably
import ably.Private
import Foundation

// Swift isn't yet smart enough to do this automatically when bridging Objective-C APIs
extension ARTChannelCollection: SequenceType {
    public func generate() -> NSFastGenerator {
        return NSFastGenerator(self)
    }
}

private func beAChannel(named channelName: String) -> MatcherFunc<ARTChannel> {
    return MatcherFunc { actualExpression, failureMessage in
        let channel = actualExpression.evaluate()
        failureMessage.expected = "expected \(channel)"
        failureMessage.postfixMessage = "be a channel"

        return channel?.name == channelName
    }
}

class RestClientChannels: QuickSpec {
    override func spec() {
        var client: ARTRest!
        var channelName: String!

        beforeEach {
            client = ARTRest(key: "fake:key")
            channelName = NSProcessInfo.processInfo().globallyUniqueString
        }

        let cipherParams = ARTCipherParams(algorithm: nil, keySpec: nil, ivSpec: nil)

        describe("RestClient") {
            // RSN1
            context("channels") {
                // RSN3
                context("get") {
                    // RSN3a
                    it("should return a channel") {
                        let channel = client.channels.get(channelName)
                        expect(channel).to(beAChannel(named: channelName))
                    }

                    // RSN3b
                    it("should return a channel with the provided options") {
                        let options = ARTChannelOptions(encrypted: cipherParams)
                        let channel = client.channels.get(channelName, options: options)

                        expect(channel).to(beAChannel(named: channelName))
                        expect(channel.options).to(beIdenticalTo(options))
                    }

                    // RSN3b
                    it("should not replace the options on an existing channel when none are provided") {
                        let channel = client.channels.get(channelName)
                        let options = channel.options

                        let newButSameChannel = client!.channels.get(channelName)

                        expect(newButSameChannel).to(beIdenticalTo(channel))
                        expect(newButSameChannel.options).to(beIdenticalTo(channel.options))
                    }

                    // RSN3c
                    it("should replace the options on an existing channel when new ones are provided") {
                        let channel = client.channels.get(channelName)
                        let oldOptions = channel.options

                        let newOptions = ARTChannelOptions(encrypted: cipherParams)
                        let newButSameChannel = client!.channels.get(channelName, options: newOptions)

                        expect(newButSameChannel).to(beIdenticalTo(channel))
                        expect(newButSameChannel.options).to(beIdenticalTo(newOptions))
                        expect(newButSameChannel.options).notTo(beIdenticalTo(oldOptions))
                    }
                }

                // RSN2
                context("channelExists") {
                    it("should check if a channel exists") {
                        expect(client.channels.exists(channelName)).to(beFalse())

                        let channel = client.channels.get(channelName)

                        expect(client.channels.exists(channelName)).to(beTrue())
                    }
                }

                // RSN4
                context("releseChannel") {
                    it("should release a channel") {
                        weak var channel = client.channels.get(channelName)

                        expect(channel).to(beAChannel(named: channelName))
                        client.channels.releaseChannel(channel!)

                        expect(channel).to(beNil())
                    }
                }

                // RSN2
                it("should be enumerable") {
                    let channels = [
                        client.channels.get(channelName),
                        client.channels.get(String(reverse(channelName)))
                    ]

                    for channel in client.channels {
                        expect(channels).to(contain(channel))
                    }
                }
            }
        }
    }
}