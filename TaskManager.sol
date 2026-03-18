// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaskManager {
    // 1. Definisi Struct Task
    struct Task {
        string description;
        bool completed;
    }

    // 2. Dynamic array of Task bernama tasks
    Task[] public tasks;

    // 3. Tambahkan tugas baru ke dalam array
    function addTask(string memory desc) public {
        tasks.push(Task(desc, false));
    }

    // 4. Tandai tugas sebagai selesai berdasarkan index
    function completeTask(uint index) public {
        require(index < tasks.length, "Index out of bounds");
        tasks[index].completed = true;
    }

    // 5. Kembalikan jumlah total tugas dalam array
    function getTaskCount() public view returns (uint) {
        return tasks.length;
    }
}
