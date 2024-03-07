add_executable(monitor monitor.cpp)

add_executable(testrandomize testrandomize.cpp)
target_link_libraries(testrandomize birdcage_shared)
add_test(NAME RandomizeTest COMMAND testrandomize)


add_executable(testcanary testcanary.cpp)
target_link_libraries(testcanary birdcage_shared)
add_test(NAME TestCanaryPass COMMAND monitor pass testcanary --ok=true)
add_test(NAME TestCanaryFail COMMAND monitor fail testcanary --ok=false)

add_executable(testsecuredata testsecuredata.cpp)
target_link_libraries(testsecuredata birdcage_shared)
add_test(NAME TestSecureDataPass COMMAND monitor pass testsecuredata --ok=true)
add_test(NAME TestSecureDataFail COMMAND monitor fail testsecuredata --ok=false)

add_executable(testsecurearray testsecurearray.cpp)
target_link_libraries(testsecurearray birdcage_shared)
add_test(NAME TestSecureArrayPass COMMAND monitor pass testsecurearray --ok=true)
add_test(NAME TestSecureArrayFail COMMAND monitor fail testsecurearray --ok=false)
