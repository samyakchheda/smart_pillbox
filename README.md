<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Pill Box</title>
</head>
<body>
    <h1>Smart Pill Box</h1>

    <h2>Overview</h2>
    <p>
        The <strong>Smart Pill Box</strong> is an innovative solution designed to assist individuals, especially the elderly and those with chronic conditions, in managing their medication intake. This project integrates IoT, AI, and software development to create a user-friendly device that ensures timely medication adherence.
    </p>

    <h2>Features</h2>
    <ul>
        <li><strong>Automated Pill Dispensing:</strong> Dispenses the correct medication at scheduled times.</li>
        <li><strong>Reminders & Notifications:</strong> Sends alerts via mobile app and sound alarms.</li>
        <li><strong>Real-time Monitoring:</strong> Tracks medication intake and provides real-time updates to caregivers.</li>
        <li><strong>Voice Recognition:</strong> Allows users to interact with the device using voice commands.</li>
        <li><strong>Data Analytics:</strong> Provides insights into medication adherence patterns.</li>
    </ul>

    <h2>Technologies Used</h2>
    <ul>
        <li><strong>Hardware:</strong> Arduino/Raspberry Pi, sensors, actuators.</li>
        <li><strong>Software:</strong> Python, C/C++</li>
        <li><strong>IoT:</strong> MQTT, HTTP, Cloud services</li>
        <li><strong>AI:</strong> Voice recognition algorithms, data analytics</li>
        <li><strong>Mobile App:</strong> Flutter/React Native</li>
    </ul>

    <h2>Installation</h2>

    <h3>Hardware Setup</h3>
    <ol>
        <li>Assemble the Smart Pill Box hardware components as per the <a href="link_to_schematic">hardware schematic</a>.</li>
        <li>Connect the hardware to the Arduino/Raspberry Pi.</li>
    </ol>

    <h3>Software Setup</h3>
    <ol>
        <li>Clone the repository:</li>
        <pre><code>git clone https://github.com/yourusername/smart-pill-box.git</code></pre>

        <li>Navigate to the project directory:</li>
        <pre><code>cd smart-pill-box</code></pre>

        <li>Install the required dependencies:</li>
        <pre><code>pip install -r requirements.txt</code></pre>

        <li>Set up the mobile app by following the instructions in the <code>mobile_app/README.md</code>.</li>
    </ol>

    <h3>IoT Setup</h3>
    <ol>
        <li>Configure the MQTT broker or cloud service details in the <code>config.json</code> file.</li>
        <li>Deploy the backend server using the provided scripts in the <code>server</code> directory.</li>
    </ol>

    <h2>Usage</h2>
    <ol>
        <li>Power on the Smart Pill Box.</li>
        <li>Use the mobile app to set up user profiles and medication schedules.</li>
        <li>The device will dispense pills at the scheduled times and send reminders.</li>
        <li>Monitor medication intake via the mobile app.</li>
    </ol>

    <h2>Contributing</h2>
    <p>
        We welcome contributions to enhance the Smart Pill Box project. Please follow these steps to contribute:
    </p>
    <ol>
        <li>Fork the repository.</li>
        <li>Create a new branch for your feature or bugfix.</li>
        <li>Commit your changes and push to your branch.</li>
        <li>Open a pull request with a detailed description of your changes.</li>
    </ol>

    <h2>License</h2>
    <p>
        This project is licensed under the MIT License. See the <a href="LICENSE">LICENSE</a> file for more details.
    </p>

    <h2>Contact</h2>
    <p>
        For any questions or suggestions, please contact us at <a href="mailto:email@example.com">email@example.com</a>.
    </p>
</body>
</html>
