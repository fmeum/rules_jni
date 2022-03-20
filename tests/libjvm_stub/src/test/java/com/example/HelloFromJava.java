// Copyright 2021 Fabian Meumertzheim
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package com.example;

import java.time.LocalDateTime;

public class HelloFromJava {
  public static String helloFromJava(String name) {
    String greeting;
    int hour = LocalDateTime.now().getHour();
    if (hour >= 5 && hour < 12) {
      greeting = "Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Afternoon";
    } else {
      greeting = "Evening";
    }
    return String.format("Good %s, %s!", greeting, name);
  }
}
