package com.samples

import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.RestController
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping

@RestController
class SampleController {

  @Value("\${kotlinapp.greeting}")
  private var greeting: String = "Hello from the SampleController."

  @GetMapping("/")
  fun blog(model: Model): String {
    return greeting
  }

}
