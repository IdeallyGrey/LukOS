# LukOS
### *LukOS was my attempt to write a basic kernel in x86 assembly. It is capable of booting, entering Protected Mode, and printing to the console.*
**Team:** Lukas Hamm

**Submission video:** [Link](https://immich.ideallygrey.uk/share/EO7G3jshKlFMZEr5R7Jhfl9MbV7VcQAfAfZHmERI5cHovynxDnNq4TGgW-kgx0TK5KI/photos/9da8da35-6139-4c22-b86d-f9837001a403)

## Inspiration
This project was inspired from my Computing Abstractions course, where we are currently in the OS unit! Additionally, I had previously come accross [a blog for writing an OS in Rust](https://os.phil-opp.com) by Philipp Oppermann, which had piqued my interest in the topic of OS devleopment. Though the vast majority of it went over my head at the time, I was pleasantly suprised when the lectures in class mentioned topics I'd read about before.

## What it does
It is able to boot in a virtual machine (theoretically it should work on bare metal? but some piece is still missing apparently), switch from 16-bit Real mode to 32-bit Protected mode, and then print to the screen (both strings and integers, with color!) via the VGA buffer.

## How I built it
It is written in x86 assembly, pulling from quite a few online resources. I've tried to link them all, they can be found in [README.md.old](./README.md.old). [MikeOS](https://mikeos.sourceforge.net/) and ["IDTKernel" by xsism (at bottom)](http://www.osdever.net/tutorials/view/interrupts-exceptions-and-idts-part-3-idts) are two x86 asm operating systems which I referenced, without which I would not have gotten as far as I did. The [OSDev Wiki](https://wiki.osdev.org) was very useful for theory, and has to many links to further information. 
## Challenges & Accomplishments
The greatest challenge was the memory segmenting involved in switching to Protected mode. I had to read a good bit until it clicked, and then used xsism's example mentioned above to see an implementation. My original--and in retrospect, itty bitty over-ambitious--goal was to implement listening for timer interupts, which is why Protected mode was important to get to.
Seeing the blue color on the screen was an aha! moment for me, and I was proud of that. I am coming away from this Hackathon with both a slightly deeper understanding of, and much greater respect for, how low level programs like kernels work.

## What's next?
The next step would be implement handling for exceptions and interrupts, thought that looks to have quite a learning curve. Maybe some day.

## Try it out

```bash
# QEMU must be installed, alternatively use your virtual machine manager of choice
git clone https://github.com/IdeallyGrey/LukOS.git
cd LukOS
qemu-system-x86_64 -cdrom LukOS.iso
```
