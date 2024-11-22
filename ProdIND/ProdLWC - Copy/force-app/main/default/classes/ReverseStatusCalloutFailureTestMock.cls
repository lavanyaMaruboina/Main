/*------------------------------------------------------------
Author:        Vishal Gadhave
Company:       Nanostuffs Technologies
Description:   Test class for IND_ReverseStatusCalloutQueueable Failure response.
Inputs:        None 
Test Classes:    
History
Date            Author              Comments
-------------------------------------------------------------
4-11-2022      Vishal               Created
------------------------------------------------------------*/
@isTest
public with sharing class ReverseStatusCalloutFailureTestMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"JData":"Jl4PH7iC6IoonMUZ6mwOQtgrCoLLa1qcl+y5j+XeUwcQYjp2+HvX7Q9syeehxtvY8Ix5lOn8EvAk5FD88FcYaiEHZ2/wB5P4u4Anq1oY5yhyT4DOH2hwlRczD6fzDe+QtB1UUCjXntW4p71Xll7Ic1mm75ulupiaLQL0zOmglixrz5BEQiTC0u8gr2XEid4SSMaXGvfD857bwQowzBRQs7CI/+mLgAd1JFGedsTkmguMnyVmJE3vUkkUlpLZp1aDGmSXwe15UqZM2hd7uSeIsIA26YfzpTEZ+rH2u3zWerKu5NK9+/74ArFd8KW7p1JJCdYPgJjrnbi5GKvcwDvid+Iik0ZUiJ7XdkW3vX2RdRaCAOSJT8EykakIKzM2gsF1PJRb33YOPxEecUdumnQqf7zKhy4w+S9ZxaYfVM6mnI13MLs/yqzCNowD5X/6LgZZi3qyBzrj4nEAahGX8093kGFxKJQCLMXmDzzM6KY/GA6L8i2cJBZHUlEYKXKc+F6u3jk3q6vKtfbrrN5Zb7FqGydTTxmwPtJ6+io5DStlQzvnPq/9qk2uPb8ZhYsbyrjRnNFTvY55Oi+uEI3eaPhF3KijOECwCo2Ff1yEuV6SMbQ="}');            
        res.setStatusCode(200);
        return res;
    }
}