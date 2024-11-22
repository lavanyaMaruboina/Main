trigger DemoTrigger on Account (before insert) {
    system.debug('data enter');
}