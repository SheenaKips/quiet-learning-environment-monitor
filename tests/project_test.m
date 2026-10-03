classdef project_test < matlab.unittest.TestCase
    
    methods(Test)
        
        function testNoiseAssessment(testCase)
            testCase.verifyFalse(isItNoisy(1.0,1.5));
            testCase.verifyTrue(isItNoisy(2.0,1.5));
        end
        
        function testLightAssessment(testCase)
            testCase.verifyFalse(isItBright(2.0,2.5));
            testCase.verifyTrue(isItBright(3.0,2.5));
        end
        
        function testFeedbackLogic(testCase)
            testCase.verifyEqual(isItGood(false,true),"Quiet and Bright");
            testCase.verifyEqual(isItGood(true,true),"Too Noisy");
            testCase.verifyEqual(isItGood(false,false),"Too Dark");
            testCase.verifyEqual(isItGood(true,false),"Noisy and Dark");
        end
        
    end
end