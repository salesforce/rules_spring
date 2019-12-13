package com.sample;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class SampleRest {
    @RequestMapping("/")
    public String hello() {
      return "Hello!";
    }
}
